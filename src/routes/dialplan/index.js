/*
 * @Author: Euan Millar 
 * @Date: 2017-07-05 01:14:16 
 * @Last Modified by: Euan Millar
 * @Last Modified time: 2017-07-05 13:36:42
 */

const Joi = require('joi');

const dialplanSchema = Joi.object().keys({
    email: Joi.string(),
    uuid:  Joi.string(),
    extensions:  Joi.string(),
    user_id:  Joi.number()
});



exports.register = (server, options, next) => {

    server.route({

        path: '/dialplan/{id}',
        method: 'GET',
        config: {
            description: 'Route to get dialplans.',
            tags: ['api'],
            plugins: {
                'hapi-swagger': {
                    payloadType: 'form'
                }
            }
        },
        handler: require('./get')
    });

    server.route({

        path: '/dialplan',
        method: 'POST',
        config: {
            description: 'PRoute to create a dialplan.',
            tags: ['api'],
            plugins: {
                'hapi-swagger': {
                    payloadType: 'form'
                }
            },
            validate: {
                payload: dialplanSchema
            }
        },
        handler: require('./post')
    });

    server.route({

        path: '/dialplan/{id}',
        method: 'PUT',
        config: {
            description: 'Protected route to update a dialplan.',
            tags: ['api'],
            plugins: {
                'hapi-swagger': {
                    payloadType: 'form'
                }
            },
            validate: {
                payload: dialplanSchema
            }
        },
        handler: require('./put')
    });

    next();
};

exports.register.attributes = {
    name: 'dialplan-routes'
};
