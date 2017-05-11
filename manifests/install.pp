# Install statsite
class statsite::install inherits statsite {

  $package      = "v${statsite::version}.tar.gz"
  $version_path = "${statsite::install_path}/statsite-${statsite::version}"

  ensure_packages($packages)
  if ($install_proxy) {
    $curl_options = "--proxy ${install_proxy}"
  } else {
    $curl_options = ""
  }

  $curl_command = "curl -LO ${curl_options} https://github.com/armon/statsite/archive/${package}"

  Exec {
    cwd  => $statsite::install_path,
    path => ['/usr/bin', '/bin'],
  }

  file { [$statsite::install_path,
          $version_path]:
    ensure => directory,
  } ->
  exec { 'statsite::install::download':
    command => $curl_command,
    unless  => "test -d ${version_path}/src",
    creates => "${statsite::install_path}/${package}",
  } ~>
  exec { 'statsite::install::extract':
    command => "tar --strip-components 1 -axf ${package} -C ${version_path}",
    creates => "${version_path}/src",
  } ~>
  exec { 'statsite::install::compile':
    cwd     => $version_path,
    command => "${version_path}/bootstrap.sh && ${version_path}/configure && make && ln -s src/statsite",
    creates => "${version_path}/src/statsite",
    require => Package[$packages],
  }

  file { "${statsite::install_path}/current":
    ensure  => link,
    target  => $version_path,
    require => Exec['statsite::install::compile'],
  }
}
