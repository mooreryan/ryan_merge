def run_it(cmd)
  begin
    $stderr.puts "\nRUNNING: #{cmd}"
    cmd_outerr = Shell.execute!(cmd)
    $stdout.puts cmd_outerr.stdout unless cmd_outerr.stdout.empty?
    $stderr.puts cmd_outerr.stderr unless cmd_outerr.stderr.empty?
    
    return cmd_outerr
  rescue RuntimeError => e
    # print stderr if bad exit status
    abort(e.message)
  end
end
