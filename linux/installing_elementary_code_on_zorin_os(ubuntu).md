# Installing elementary code on Zorin OS #     
(Should be the same for any ubuntu system) 

As explained in the offical github page for elementary code, you need  granite 5.2.0 or above. Problem is, installing from apt doesn't get you a high enough version. Installing from a deb file might not work either. So...    
`Dependency granite found: NO found '0.5' but need: '>= 5.2.0'`
`meson.build:17:0: ERROR: Invalid version of dependency, need 'granite' ['>= 5.2.0'] found '0.5'.`

On my system, meson wasn't working properly either, so I installed it with pip. Here are the steps...


Dependencies
----
```
sudo apt install meson
sudo apt install libeditorconfig-dev
sudo apt install libgail-3-dev
sudo apt install libgee-0.8-dev 
sudo apt install libgtksourceview-3.0-dev 
sudo apt install libgtkspell3-3-dev
sudo apt install libgranite-dev
sudo apt install libgit2-glib-1.0-dev
sudo apt install libpeas-dev
sudo apt install libsoup2.4-dev
sudo apt install libvala-0.40-dev 
sudo apt install libvte-2.91-dev
sudo apt install libwebkit2gtk-4.0-dev
sudo apt install libzeitgeist-2.0-dev
sudo apt install valac
sudo apt install python3-pip
pip3 install meson
```

Building granite & code
----
```
cd /home/kcaps/Dev/git
git clone https://github.com/elementary/code.git
git clone https://github.com/elementary/granite.git
cd granite
meson build --prefix=/usr
cd build
ninja && sudo ninja install
cd ../../code/
meson build --prefix=/usr
cd build
ninja && sudo ninja install
```

After this I could run it just fine, io.elementary.code from the terminal and as "Code" from the applications menu, just as in Elementary OS.    
Running `apt autoremove` deleted granite and I had to build it again, `ninja && ninja install` in the git build directory
