/*
 * @Author: Euan Millar 
 * @Date: 2017-07-05 01:14:20 
 * @Last Modified by: Euan Millar
 * @Last Modified time: 2017-07-06 00:44:08
 */
const Boom = require('boom');
const Dialplan = require('../../model/dialplan');

module.exports = (request, reply) => {

    Dialplan
        .where('user_id', request.params.id)
        .fetchAll()
        .then((dialplan) => {

            if (!dialplan) {
                reply(Boom.badRequest('No dialplan available.'));
            }
            else {
                const data = {
                    message: 'dialplan success',
                    dialplan
                };
                reply(data);
            }
        })
        .catch((err) => {

            if (err){
                reply(Boom.badImplementation('terrible implementation on dialplan ' + err));
            }
        });
};
