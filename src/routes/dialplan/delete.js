
/*
 * @Author: Euan Millar 
 * @Date: 2017-07-05 01:14:12 
 * @Last Modified by: Euan Millar
 * @Last Modified time: 2017-07-28 12:24:28
 */

const Boom = require('boom');
const Dialplan = require('../../model/dialplan');

module.exports = (request, reply) => {

    new Dialplan({ id:parseInt(request.params.id) }).destroy({ require: true })
        .then(() => {

            const responseData = {
                message: 'Dialplan destroyed'
            };
            reply(responseData);
        }).catch((err) => {

            reply(Boom.badImplementation('Cant delete dialplan ' + err));

        });

};
