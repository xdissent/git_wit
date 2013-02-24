module GitWit
  module Commands
    module Debug
      def debug
        boot_app
        require "pp"
        debug_banner "Start"
        pp "ENVIRONMENT:", ENV
        GitWit.configure { |c| pp "GitWit Config:", c }
        debug_banner "End"
        $stdout.flush
        exec_with_sudo!
      end

      protected
      def debug_banner(msg = nil)
        msg = "#{msg} " if msg.present?
        puts "\n" * 2 + "*" * 5 + " GitWit DEBUG #{msg}" + "*" * 5 + "\n" * 2
      end
    end
  end
end