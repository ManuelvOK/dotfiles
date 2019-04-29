cp -R /usr/include/c++/$GCC_VERSION ~/.vim/cpp_src
# it is not necessary to rename headers without an extension
# replace the "namespace std" with "namespace std"
find . -type f | xargs sed -i 's/namespace std/namespace std/'
mkdir tags
ctags -f tags/tags -R --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -I _GLIBCXX_NOEXCEPT cpp_src
rm -r cpp_src
