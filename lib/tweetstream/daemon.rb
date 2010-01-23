require 'daemons'

# A daemonized TweetStream client that will allow you to
# create backgroundable scripts for application specific
# processes. For instance, if you create a script called
# <tt>tracker.rb</tt> and fill it with this:
#
#     require 'rubygems'
#     require 'tweetstream'
#
#     TweetStream::Daemon.new('user','pass', :app_name => 'tracker').track('intridea') do |status|
#       # do something here
#     end
#
# And then you call this from the shell:
#
#     ruby tracker.rb start
#
# A daemon process will spawn that will automatically
# run the code in the passed block whenever a new tweet
# matching your search term ('intridea' in this case)
# is posted.
#
class TweetStream::Daemon < TweetStream::Client
  # Initialize a Daemon with the credentials of the
  # Twitter account you wish to use. The daemon has
  # an optional daemon_options parameter for passing 
  # additional parameters to the daemon.
  # === daemon_options:
  # <tt>:app_name</tt>::  The name of the application. This will be
  #                       used to contruct the name of the pid files
  #                       and log files. Defaults to the basename of
  #                       the script.
  # <tt>:ARGV</tt>::      An array of strings containing parameters and switches for Daemons.
  #                       This includes both parameters for Daemons itself and the controlled scripted.
  #                       These are assumed to be separated by an array element '--', .e.g.
  #                       ['start', 'f', '--', 'param1_for_script', 'param2_for_script'].
  #                       If not given, ARGV (the parameters given to the Ruby process) will be used.
  # <tt>:dir_mode</tt>::  Either <tt>:script</tt> (the directory for writing the pid files to 
  #                       given by <tt>:dir</tt> is interpreted relative
  #                       to the script location given by +script+) or <tt>:normal</tt> (the directory given by 
  #                       <tt>:dir</tt> is interpreted as a (absolute or relative) path) or <tt>:system</tt> 
  #                       (<tt>/var/run</tt> is used as the pid file directory)
  #
  # <tt>:dir</tt>::       Used in combination with <tt>:dir_mode</tt> (description above)
  # <tt>:multiple</tt>::  Specifies whether multiple instances of the same script are allowed to run at the
  #                       same time
  # <tt>:ontop</tt>::     When given (i.e. set to true), stay on top, i.e. do not daemonize the application 
  #                       (but the pid-file and other things are written as usual)
  # <tt>:mode</tt>::      <tt>:load</tt> Load the script with <tt>Kernel.load</tt>;
  #                       <tt>:exec</tt> Execute the script file with <tt>Kernel.exec</tt>
  # <tt>:backtrace</tt>:: Write a backtrace of the last exceptions to the file '[app_name].log' in the 
  #                       pid-file directory if the application exits due to an uncaught exception
  # <tt>:monitor</tt>::   Monitor the programs and restart crashed instances
  # <tt>:log_output</tt>:: When given (i.e. set to true), redirect both STDOUT and STDERR to a logfile named '[app_name].output' in the pid-file directory
  # <tt>:keep_pid_files</tt>:: When given do not delete lingering pid-files (files for which the process is no longer running).
  # <tt>:hard_exit</tt>:: When given use exit! to end a daemons instead of exit (this will for example
  #                       not call at_exit handlers).
  # -----

  def initialize(user, pass, daemon_options = {})
    @daemon_options = {:app_name => 'tweetstream', :multiple => true}.merge(daemon_options)
    super(user, pass)
  end
  
  def start(path, query_parameters = {}, &block) #:nodoc:
    Daemons.run_proc(@daemon_options[:app_name], @daemon_options) do
      super(path, query_parameters, &block)
    end
  end
end
