MRuby::Build.new do |conf|
  # load specific toolchain settings

  # Gets set by the VS command prompts.
  if ENV['MRUBY_TOOLCHAIN']
    toolchain ENV['MRUBY_TOOLCHAIN']
  elsif ENV['VisualStudioVersion'] || ENV['VSINSTALLDIR']
    toolchain :visualcpp
  else
    toolchain :gcc
  end

  # enable_debug

  # use mrbgems
  Dir.glob("../mruby-*/mrbgem.rake") do |x|
    g = File.basename File.dirname x
    if g == 'mruby-onig-regexp'
      conf.gem "../deps/#{g}" do |c|
        c.bundle_onigmo
      end
    else
      conf.gem "../deps/#{g}"
    end
  end

  # include all the core GEMs
  conf.gembox 'full-core'
end

MRuby::CrossBuild.new('arm-linux-gnueabi') do |conf|
  toolchain :gcc

  conf.cc.command       = ENV['CROSS_COMPILE'] + 'gcc'
  conf.cxx.command      = ENV['CROSS_COMPILE'] + 'g++'
  conf.linker.command   = ENV['CROSS_COMPILE'] + 'gcc'
  conf.archiver.command = ENV['CROSS_COMPILE'] + 'ar'
#  conf.cc.flags << "-m32"
#  conf.linker.flags << "-m32"

  # include all the core GEMs
  conf.gembox 'full-core'

  conf.build_mrbtest_lib_only

  #conf.gem 'examples/mrbgems/c_and_ruby_extension_example'

  conf.test_runner.command = 'env'

  # use mrbgems
  Dir.glob("../mruby-*/mrbgem.rake") do |x|
    g = File.basename File.dirname x
    if g == 'mruby-onig-regexp'
      conf.gem "../deps/#{g}" do |c|
        c.bundle_onigmo
      end
    else
      conf.gem "../deps/#{g}"
    end
  end

end
