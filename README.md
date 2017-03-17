````shell
brew install sqlite --force --with-fts5

# or

brew reinstall sqlite --force --with-fts5
````

````
./bin/walmart add 'https://www.walmart.com/ip/Ematic-9-Dual-Screen-Portable-DVD-Player-with-Dual-DVD-Players-ED929D/28806789'
./bin/walmart add 'https://www.walmart.com/ip/Refurbished-Apple-iPhone-5s-16GB-Smartphone-Unlocked-White-Silver/49053767'

./bin/walmart view 28806789
./bin/walmart view 49053767

./bin/walmart reviews '28806789' ''
./bin/walmart reviews '28806789' 'bad'
./bin/walmart reviews '28806789' 'godd'
````
