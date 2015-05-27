class SignaturesController < ApplicationController
  before_filter :retrieve_petition, :only => [:new, :create, :thank_you, :signed]
  include ActionView::Helpers::NumberHelper

  respond_to :html

  def new
    assign_stage
    @stage_manager = Staged::PetitionSigner.manage(signature_params_for_new, @petition, params[:stage], params[:move])
    respond_with @stage_manager.stage_object
  end

  def create
    matching_signatures = find_existing_pending_signatures
    if matching_signatures.any?
      handle_existing_signatures(matching_signatures, @petition)
    else
      handle_new_signature(@petition)
    end
  end

  def verify
    @signature = Signature.find(params[:id])

    if @signature.validate_from_token!(params[:token])
      # if signature is that of the petition's creator, mark the petition as validated
      if @signature.petition.creator_signature == @signature
        @signature.petition.state = Petition::VALIDATED_STATE
        @signature.petition.notify_sponsors
        @signature.petition.save!

      # else signature is from an ordinary signee so let's redirect to petition's page
      else
        redirect_to signed_petition_signature_url(@signature.petition) and return
      end
    else
      # We've found the signature, but it's already been verified.
      if @signature.state == Signature::VALIDATED_STATE
        flash[:notice] = "Thank you. Your signature has already been added to the <span class='nowrap'>e-petition</span>."
        redirect_to signed_petition_signature_url(@signature.petition) and return
      else
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  def unsubscribe
    signature = Signature.find(params[:id])
    if signature.unsubscribe_token != params[:unsubscribe_token]
      render 'signatures/unsubscribe/failed_to_unsubscribe'
    elsif signature.unsubscribed?
      render 'signatures/unsubscribe/already_unsubscribed'
    else
      signature.unsubscribe!
      render 'signatures/unsubscribe/successfully_unsubscribed'
    end
  end

  private
  def retrieve_petition
    @petition = Petition.visible.find(params[:petition_id])
  end

  def send_email_to_petition_signer(signature)
    PetitionMailer.email_confirmation_for_signer(signature).deliver_now
  end

  def assign_stage
    return if Staged::PetitionSigner.stages.include? params[:stage]
    params[:stage] = 'signer'
  end

  def signature_params_for_new
    {country: 'United Kingdom'}
  end

  def signature_params_for_create
    @_signature_params_for_create ||=
      params.
        require(:signature).
        permit(:name, :email, :email_confirmation,
               :postcode, :country, :uk_citizenship)
  end

  def find_existing_pending_signatures
    @signature = Signature.new(signature_params_for_create)
    @signature.email.strip!
    @signature.petition = @petition
    Signature.pending.matching(@signature)
  end

  def handle_existing_signatures(signatures, petition)
    signatures.each { |sig| send_email_to_petition_signer(sig) }
    redirect_to thank_you_petition_signature_url(petition)
  end

  def handle_new_signature(petition)
    assign_stage
    @stage_manager = Staged::PetitionSigner.manage(signature_params_for_create, petition, params[:stage], params[:move])
    if @stage_manager.create_signature
      send_email_to_petition_signer(@stage_manager.signature)
      respond_with @stage_manager.stage_object, :location => thank_you_petition_signature_url(petition)
    else
      render :new
    end
  end
end
