/*
 * @Author: Euan Millar 
 * @Date: 2017-07-05 01:14:16 
 * @Last Modified by: Euan Millar
 * @Last Modified time: 2017-07-05 13:36:42
 */

const Joi = require('joi');

const userSchema = Joi.object().keys({
    email: Joi.string(),
    username: Joi.string(),
    password: Joi.string(),
    extension: Joi.string(),
    given: Joi.string(),
    family: Joi.string(),
    uuid: Joi.string(),
    avatar: Joi.string(),
    address: Joi.string()
});

exports.register = (server, options, next) => {

    server.route({

        path: '/users',
        method: 'GET',
        config: {
            description: 'Route to get users.',
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

        path: '/users',
        method: 'POST',
        config: {
            description: 'PRoute to create a user.',
            tags: ['api'],
            plugins: {
                'hapi-swagger': {
                    payloadType: 'form'
                }
            },
            validate: {
                payload: userSchema
            }
        },
        handler: require('./post')
    });

    server.route({

        path: '/users/{id}',
        method: 'PUT',
        config: {
            description: 'Protected route to update a user.',
            tags: ['api'],
            plugins: {
                'hapi-swagger': {
                    payloadType: 'form'
                }
            },
            validate: {
                payload: userSchema
            }
        },
        handler: require('./put')
    });

    next();
};

exports.register.attributes = {
    name: 'user-routes'
};
