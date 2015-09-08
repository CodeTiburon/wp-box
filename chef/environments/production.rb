# Author: Nickolay U. Kofanov
# Company: CodeTiburon
# Date: 2015-02-27

name "production"
description "Production environment"

override_attributes(
  :ctwp => {
    :debug_mode => false,
  },
  :php => {
    :directives => {
      :display_errors => '0',
      :display_startup_errors => '0',
      :error_reporting => 'E_ALL & ~E_DEPRECATED'
    }
  }
)