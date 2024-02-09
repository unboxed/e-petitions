namespace :bundle do
  desc "Audit bundle for any known vulnerabilities"
  task :audit do
    unless system "bundle-audit check"
      exit 1
    end
  end
end
