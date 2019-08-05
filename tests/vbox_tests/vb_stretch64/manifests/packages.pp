class plone {

  package { "build-essential":
    ensure => present,
  }
  package { "python-dev":
    ensure => present,
  }
  package { "libjpeg-dev":
    ensure => present,
  }
  package { "libxml2-dev":
    ensure => present,
  }
  package { "libxslt-dev":
    ensure => present,
  }

}

include plone
