#!/bin/bash
set -euo pipefail # 严格模式

BUILD_GRADLE_PATH="./android/app/build.gradle"

if [ ! -f "$BUILD_GRADLE_PATH" ]; then
    echo "Error: $BUILD_GRADLE_PATH not found after expo prebuild!"
    exit 1
fi

echo "Adding ABI splits configuration to $BUILD_GRADLE_PATH..."

# 使用 awk 来实现插入，比 sed 在多行插入时更易读和健壮
# 注意：整个 awk 脚本块现在用单引号 ' 包裹，内部的字符串用双引号 "
awk '
/apply from: "../../node_modules/expo-router/expo-router-app.gradle"/ {
    print; # 打印匹配到的行
    print ""; # 插入一个空行
    print "    splits {";
    print "        abi {";
    print "            enable true";
    print "            reset()";
    print "            include \"armeabi-v7a\", \"arm64-v8a\", \"x86\", \"x86_64\""; # 注意这里的双引号需要转义
    print "        }";
    print "    }";
    next; # 处理完这一行后跳到下一行
}
{
    print # 打印其他行
}' "$BUILD_GRADLE_PATH" > "${BUILD_GRADLE_PATH}.tmp" && mv "${BUILD_GRADLE_PATH}.tmp" "$BUILD_GRADLE_PATH"

echo "Modified $BUILD_GRADLE_PATH content:"
cat "$BUILD_GRADLE_PATH"
