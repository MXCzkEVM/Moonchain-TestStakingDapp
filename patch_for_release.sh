#! /bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ ! -e build/web ]; then
    echo "Build output not found."
    echo "Please run 'flutter build web' to generate the output."
    exit 1
fi

#
echo "[Patching the flutter_bootstrap.js.]"
sed -i "s/\"main.dart.js\"/\`main.dart.js?v=\${Date.now()}\`/g" build/web/flutter_bootstrap.js


#
cd $SCRIPT_DIR
echo "[Done]"
