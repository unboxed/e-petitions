module Staged
  module PetitionSigner
    module Stages
      def self.stage_names
        ['signer', 'replay-email', 'done']
      end

      def self.initial_stage
        for_name('signer')
      end

      def self.for_name(name)
        case name
        when 'signer'
          self::Signer
        when 'replay-email'
          self::ReplayEmail
        when 'done'
          self::Done
        else
          self::Signer
        end
      end

      class Signer < Staged::Stage
        def stage_object
          @_stage_object ||= ::Staged::PetitionSigner::Signer.new(model)
        end

        def name; 'signer'; end
        def go_back; self; end
        def go_next; Stages.for_name('replay-email').new(model); end
      end

      class ReplayEmail < Staged::Stage
        def stage_object
          @_stage_object ||= ::Staged::PetitionSigner::ReplayEmail.new(model)
        end

        def name; 'replay-email'; end
        def go_back; Stages.for_name('signer').new(model); end
        def go_next; Stages.for_name('done').new(model); end
      end

      class Done < Staged::Stage
        def stage_object; model; end
        def name; 'done'; end
        def go_back; self; end
        def go_next; self; end
        def complete?; true; end
      end
    end
  end
end
