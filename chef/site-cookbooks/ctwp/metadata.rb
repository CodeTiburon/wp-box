name "ctwp"
description "CodeTiburon WordPress cookbook"
maintainer "Nickolay U. Kofanov"
maintainer_email "n.kofanov@codetiburon.com"
version "1.0.0"
license "Proprietary - All Rights Reserved"

supports "ubuntu"

depends "apache2"
depends "mysql", "= 3.0.4"
depends "php"
depends "iptables"
depends "rsync"