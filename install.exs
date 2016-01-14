defmodule BakeInstaller do
  @bake_version "0.1.1"
  import IO, only: [puts: 1]

  def windows_install_deps do
    puts "windows install deps"
  end

  def osx_install_deps do
    puts "osx install deps"
  end

  def linux_install_deps do
    puts "linux install deps"
  end

  def install_bake(install_prefix, bake_home) do
    puts "install bake"
  end

  def install({:unix, :linux}) do
    home_dir = '~/.bake'
    install_dir = home_dir + '/bin'

    linux_install_deps
    install_bake(install_dir, home_dir)

    puts "Be sure to add #{install_dir} to your path"
  end

  def install({:unix, :darwin}) do
    osx_install_deps
    install_bake('/usr/local/bin', '~/.bake')
  end

  def install({:win32, :nt}) do
    puts "Windows support coming soon"
  end
end

:os.type |> BakeInstaller.install()
