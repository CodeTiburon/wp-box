# Author: Nickolay U. Kofanov
# Company: CodeTiburon
# Date: 2015-02-27

name "development"
description "Development envrionemnt"

override_attributes ({
  :ctwp => {
    :debug_mode => true,
  },
  :php => {
    :directives => {
      :display_errors => '1',
      :display_startup_errors => '1',
      :error_reporting => '-1'
    }
  }
})