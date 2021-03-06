#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
appdir="$(cd $DIR && cd ../ && pwd)"

#Killing running script
if [ -n $(pm2 -V) ] 
then
	ezseed stop
else
	npm i pm2 -g
fi

rm ~/.pm2/custom_options.sh
touch ~/.pm2/custom_options.sh

echo "export PM2_NODE_OPTIONS='--stack_size=1400'" >> ~/.pm2/custom_options.sh
echo "export NODE_ENV=production" >> ~/.pm2/custom_options.sh

cd $appdir

if [ -d "$appdir/app/scripts" ]
then
	mv "$appdir/app/scripts" "$appdir/scripts"
fi

echo "Getting changes from github"
# Clean the directory, but don't remove files specified in .gitignore.
git clean -f
# Reset the files
git reset --hard HEAD
# Get the changes
git pull -f

echo "Installing dependecies"
npm cache clear -f
npm i --production
npm link

# echo "Ezseed is up to date starting"
# pm2 start "$appdir/ezseed.json"
exit 0