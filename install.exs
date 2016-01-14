defmodule BakeInstaller do  
  import IO, only: [puts: 1]
  import Mix.Utils, only: [read_path: 2]

  @bake_version "0.1.1"

  @bake_url "https://s3.amazonaws.com/bakeware/bake/bake-#{@bake_version}.tar.gz"
  @bake_sha512 "ea71ff9ef5d8737064525a4835483bd489f54f7afad80c6b8d739b943912ea57414b35b4d7823c793c8f4e2f469629dd9e71625d01d12efbd039ecd3820b6171"

  # FIXME this is silly, make the bake url be the direct path to escript and drop this step
  @win32_untar_url "http://bitbucket.org/svnpenn/a/downloads/go-untar.exe"
  @win32_untar_sha512 "a8008f1cf02d8bf8361cb9e7a87886e8a462ba942bbf13f7eba4629a22d0451c6e7162bf878e7fc4f966b6f34c198a2e8453280b296fc8a5c71bd2a6355ca235"

  @doc """
  Run a script through bash or powershell using System.cmd
  Returns {stdout, exitstatus}
  See System.cmd for more info
  Options:
    :powershell - run the command run using powershell instead of bash
  Options are also forwarded to System.cmd
  """
  def system(shell_cmd, opts \\ []) do
    Keyword.put(opts, :into, IO.stream(:stdio, :line))
    if Keyword.get(opts, :powershell) do
      opts = Keyword.delete(opts, :powershell)
      System.cmd("powershell", [shell_cmd], opts)
    else
      System.cmd("bash", ["-c", shell_cmd], opts)
    end
  end

  def windows_install_deps do
    # TODO install fwup and squashfs
  end

  def get(url, dest, sha512) do
    {:ok, data} = read_path(url, sha512: sha512)
    File.write!(dest, data)
  end

  def ps_mkdirp(path), do: "New-Item -path \"#{path}\" -Force -type directory"

  def osx_install_deps do
    {_, exitstatus} = system("brew --version")
    if exitstatus != 0 do
      raise "Homebrew not installed"
    end
    puts "=> Preparing to install bake"
    puts "=> Updating Homebrew Deps"
    {_, exitstatus} = system("brew update")
    if exitstatus != 0 do
      raise "Could not update homebrew. Please run brew doctor and try again."
    end
    {_, exitstatus} = system("brew install fwup")
    if exitstatus != 0 do
      raise "Could not install fwup. Please run brew doctor and try again."
    end
    {_, exitstatus} = system("brew install squashfs")
    if exitstatus != 0 do
      raise "Could not install squashfs. Please run brew doctor and try again."
    end
  end

  def linux_install_deps do
    {_, exitstatus} = system("fwup --version >/dev/null")
    if exitstatus != 0 do
      raise "fwup v0.5.0 or later required. See https://github.com/fhunleth/fwup"
    end

    {_, exitstatus} = system("mksquashfs -version >/dev/null")
    if exitstatus != 0 do
      raise "mksquashfs required. Install squashfs-tools. E.g. sudo apt-get install squashfs-tools"
    end
  end

  def unix_install_bake(install_prefix, bake_home) do
    puts "=> Creating bake home"
    system("mkdir -p #{bake_home}")
    tarball = "#{bake_home}/bake.tar.gz"

    puts "=> Downloading latest bake"
    :ok = get(@bake_url, tarball, @bake_sha512)

    {_, exitstatus} = system("mkdir -p #{install_prefix}")
    if exitstatus != 0 do
      raise "Error creating installation directory #{install_prefix}"
    end

    {_, exitstatus} = system("tar -xf #{tarball} -C #{install_prefix}")
    if exitstatus != 0 do
      raise "Bake did not install correctly. Check permissions on #{install_prefix}."
    end

    system("rm #{bake_home}/bake.tar.gz")

    puts "=> bake version #{@bake_version} installed to #{install_prefix}"
  end

  def windows_install_bake(install_prefix, bake_home) do
    win = [powershell: true]
    puts "=> Creating bake home"
    bake_home |> ps_mkdirp() |> system(win)

    tarball = "#{bake_home}\\bake.tar.gz"
    untar = "#{bake_home}\\go-untar.exe"

    puts "=> Downloading latest bake"
    :ok = get(@bake_url, tarball, @bake_sha512)

    puts "=> Downloading untar tool"
    :ok = get(@win32_untar_url, untar, @win32_untar_sha512)

    {_, exitstatus} = install_prefix |> ps_mkdirp() |> system(win)
    if exitstatus != 0 do
      raise "Error creating installation directory #{install_prefix}"
    end

    {_, exitstatus} = "Set-Location #{install_prefix}; #{untar} #{tarball}" |> system(win)
    if exitstatus != 0 do
      raise "Bake did not install correctly. Check permissions on #{install_prefix}."
    end

    system("Remove-Item #{tarball}; Remove-Item #{untar}", win)

    puts "=> bake version #{@bake_version} installed to #{install_prefix}"
  end


  def init({:unix, :linux}) do
    home_dir = "#{System.get_env("HOME")}/.bake"
    install_dir = home_dir <> "/bin"

    linux_install_deps
    unix_install_bake(install_dir, home_dir)

    puts "Be sure to add #{install_dir} to your path"
  end

  def init({:unix, :darwin}) do
    osx_install_deps
    unix_install_bake('/usr/local/bin', "#{System.get_env("HOME")}/.bake")
  end

  def init({:win32, :nt}) do
    home_dir = System.get_env("USERPROFILE") <> "\\.bake"
    install_dir = home_dir <> "\\bin"
    
    windows_install_deps
    windows_install_bake(install_dir, home_dir)

    puts "Be sure to add #{install_dir} to your path"
    puts "Try running bake now\n\tescript #{install_dir}\\bake --version"
  end

  def init({family, name}) do
    puts "Sorry, support for {:#{family}, :#{name}} isn't implemented yet."
  end
end

:os.type() |> BakeInstaller.init()
