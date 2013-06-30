class plone {

  package { "build-essential":
    ensure => present,
  }
  package { "libjpeg-dev":
    ensure => present,
  }

  package { "libssl-dev":
    ensure => present,
  }

}

include plone
