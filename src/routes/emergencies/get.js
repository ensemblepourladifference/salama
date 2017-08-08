/*
 * @Author: Euan Millar 
 * @Date: 2017-07-05 01:14:20 
 * @Last Modified by: Euan Millar
 * @Last Modified time: 2017-07-06 00:44:08
 */
const Boom = require('boom');
const Emergency = require('../../model/emergency');

module.exports = (request, reply) => {

    Emergency
        .where({ user_id: request.params.id, active: true })
        .fetch()
        .then((emergency) => {

            if (!emergency) {
                reply(Boom.badRequest('No emergency available.'));
            }
            else {
                const responseData = {
                    message: 'emergency success',
                    emergency
                };
                reply(responseData);
            }
        })
        .catch((err) => {

            if (err){
                reply(Boom.badImplementation('terrible implementation on emergency ' + err));
            }
        });
};
