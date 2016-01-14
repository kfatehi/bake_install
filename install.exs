defmodule BakeInstaller do  
  import IO, only: [puts: 1]

  @bake_version "0.1.1"

  # FIXME it's a binary, why is it a tar.gz, we save next to nothing and only increase risk and complexity
  @bake_url "https://s3.amazonaws.com/bakeware/bake/bake-#{@bake_version}.tar.gz"

  # FIXME this is untrusted, make the bake url be the direct path to binary and drop this
  @win32_untar_url "http://bitbucket.org/svnpenn/a/downloads/go-untar.exe"

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

  def ps_download(url, dest), do: "(new-object net.webclient).DownloadFile(\"#{url}\", \"#{dest}\")"
  def ps_mkdirp(path), do: "New-Item -path \"#{path}\" -Force -type directory"

  def windows_install_bake(install_prefix, bake_home) do
    win = [powershell: true]
    puts "=> Creating bake home"
    bake_home |> ps_mkdirp() |> system(win)

    tarball = "#{bake_home}\\bake.tar.gz"
    untar = "#{bake_home}\\go-untar.exe"

    puts "=> Downloading latest bake"

    {_, exitstatus} = @bake_url |> ps_download(tarball) |> system(win)
    if exitstatus != 0 do
      raise "Failed to download bake tarball!"
    end

    puts "=> Downloading untar tool"
    {_, exitstatus} = @win32_untar_url |> ps_download(untar) |> system(win)
    if exitstatus != 0 do
      raise "Failed to download bake tarball!"
    end

    {_, exitstatus} = install_prefix |> ps_mkdirp() |> system(win)
    if exitstatus != 0 do
      raise "Error creating installation directory #{install_prefix}"
    end

    extract = "Set-Location #{install_prefix}; #{untar} #{tarball}"
    {_, exitstatus} = extract |> system(win)
    if exitstatus != 0 do
      raise "Bake did not install correctly. Check permissions on #{install_prefix}."
    end

    #system("Remove-Item #{tarball}", win)
    system("Remove-Item #{untar}", win)

    puts "=> bake version #{@bake_version} installed to #{install_prefix}"
  end

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

  def install_bake(install_prefix, bake_home) do
    puts "=> Creating bake home"
    system("mkdir -p #{bake_home}")

    puts "=> Downloading latest bake"
    {_, exitstatus} = system("curl -o #{bake_home}/bake.tar.gz -L https://s3.amazonaws.com/bakeware/bake/bake-#{@bake_version}.tar.gz")
    if exitstatus != 0 do
      raise "Failed to download bake tarball!"
    end

    {_, exitstatus} = system("mkdir -p #{install_prefix}")
    if exitstatus != 0 do
      raise "Error creating installation directory #{install_prefix}"
    end

    {_, exitstatus} = system("tar -xf #{bake_home}/bake.tar.gz -C #{install_prefix}")
    if exitstatus != 0 do
      raise "Bake did not install correctly. Check permissions on #{install_prefix}."
    end

    system("rm #{bake_home}/bake.tar.gz")

    puts "=> bake version #{@bake_version} installed to #{install_prefix}"
  end

  def init({:unix, :linux}) do
    home_dir = "~/.bake"
    install_dir = home_dir <> "/bin"

    linux_install_deps
    install_bake(install_dir, home_dir)

    puts "Be sure to add #{install_dir} to your path"
  end

  def init({:unix, :darwin}) do
    osx_install_deps
    install_bake('/usr/local/bin', '~/.bake')
  end

  def init({:win32, :nt}) do
    home_dir = System.get_env("USERPROFILE") <> "\\.bake"
    install_dir = home_dir <> "\\bin"
    
    windows_install_deps
    windows_install_bake(install_dir, home_dir)

    puts "Be sure to add #{install_dir} to your path"
  end

  def init({family, name}) do
    puts "Sorry, support for {:#{family}, :#{name}} isn't implemented yet."
  end
end

:os.type() |> BakeInstaller.init()
