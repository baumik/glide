require 'rubygems'

desc 'compile coffeescript into javascript'
task :coffee do
  system 'coffee -co dist/ src/coffee/*.coffee'
  system 'coffee -c demo/app/*.coffee'
end

desc 'compile less into css'
task :less do
  system 'lessc --yui-compress src/less/glide.less dist/glide.css'
  system 'lessc --yui-compress src/less/glide.android.less dist/glide.android.css'
  system 'lessc --yui-compress src/less/theme/glide.theme.less dist/glide.theme.css'
end

task :publish do
  ENV['GIT_DIR'] = File.expand_path(`git rev-parse --git-dir`.chomp)
  old_sha = `git rev-parse refs/remotes/origin/gh-pages`.chomp
  Dir.chdir('demo') do
    ENV['GIT_INDEX_FILE'] = gif = '/tmp/dev.gh.i'
    ENV['GIT_WORK_TREE'] = Dir.pwd
    File.unlink(gif) if File.file?(gif)
    `git add -A`
    tsha = `git write-tree`.strip
    puts "Created tree   #{tsha}"
    if old_sha.size == 40
      csha = `echo 'boom' | git commit-tree #{tsha} -p #{old_sha}`.strip
    else
      csha = `echo 'boom' | git commit-tree #{tsha}`.strip
    end
    puts "Created commit #{csha}"
    puts `git show #{csha} --stat`
    puts "Updating gh-pages from #{old_sha}"
    `git update-ref refs/heads/gh-pages #{csha}`
    `git push origin gh-pages`
  end
end

task :default => [:coffee, :less]
