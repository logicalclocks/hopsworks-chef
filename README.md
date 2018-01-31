# Development Tips


## Javascript/HTML development on localhost
If you are only editing javascript or html code, you can easily debug and view your changes by running the script:

````
cd scripts
./local-deploy.sh
````

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Develop
You probably want to change the Vagrantfile - ports. And you don't want this change to affect your push/pull
````
git update-index --skip-worktree Vagrantfile
````
and when you actually want to change something and push it
````
git update-index --no-skip-worktree Vagrantfile
````
