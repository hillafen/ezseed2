var db = require(global.app_path + '/app/core/database')
  , async = require('async')
  , daemon = require('../../lib/daemon.js');

var rtorrent_daemon = function (cmd, options) {

	if(options.user) {

		daemon('rutorrent', cmd, options.user, function() {

			process.exit(0);

		});

	} else {

		db.users.getAll(function(err, users) {

			async.each(users,

				function(user, cb) {

					if(user.client == 'rutorrent') {

						daemon('rutorrent', cmd, user.username, function() {

							global.log('info', user.username + " " + cmd + "ed");
							cb();

						});

					} else {
						global.log('info', user.username + "is using "+user.client+", skipping");
						cb();
					}

				},
				function(err) {

					if(err) global.log('error', err);

					global.log('info', "Success");
					process.exit(0);

				}
			);

		});
	}

}

module.exports = function (program) {

	program
		.command('rtorrent <start|stop|restart>')
		.option('-u, --user <username>', 'username')
		.description('stop rtorrent daemon(s)')
		.action(rtorrent_daemon);
}