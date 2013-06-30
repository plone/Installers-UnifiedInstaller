class packages {

  package { "gcc-c++":
    ensure => present,
  }

  package { "patch":
    ensure => present,
  }

  package { "openssl-devel":
    ensure => present,
  }

  package { "libjpeg-turbo-devel":
    ensure => present,
  }

  package { "readline-devel":
    ensure => present,
  }

  package { "make":
    ensure => present,
  }

  package { "which":
    ensure => present,
  }

}

include packages