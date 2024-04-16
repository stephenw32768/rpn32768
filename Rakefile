task :test do
  require_relative './test/evaluator_test'
end

task :install, [:prefix] do |t, args|
  prefix = args[:prefix]
  if prefix
    bin_dir="#{prefix}/bin"
    install_dir="#{prefix}/share/ruby/rpn32768"
    FileUtils.mkdir_p(bin_dir)
    FileUtils.mkdir_p(install_dir)
    File.open("#{bin_dir}/rpn", 'w') do |wrapper_target|
      IO.readlines('src/sh/rpn').each do |wrapper_line|
        if wrapper_line.start_with?('install_dir=')
          wrapper_target.puts("install_dir=\"#{install_dir}\"")
        else
          wrapper_target.puts(wrapper_line)
        end
      end
      wrapper_target.chmod(0755)
    end
    FileUtils.copy_entry('src/ruby', install_dir)
    FileUtils.cp('rpn32768help.txt', install_dir)
  else
    puts "Usage: rake install[PREFIX]"
    puts "e.g. if PREFIX is /usr/local, installs to /usr/local/share/ruby"
    puts "and puts the wrapper script in /usr/local/bin"
  end
end