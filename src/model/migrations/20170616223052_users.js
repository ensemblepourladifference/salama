exports.up = function (knex, Promise) {

    return knex.schema.createTable('users', (table) => {

        table.increments('id').primary();
        table.string('email').nullable().unique();
        table.string('username').nullable().unique();
        table.string('password').nullable();
        table.string('extension').nullable().unique();
        table.string('given').nullable();
        table.string('family').nullable();
        table.string('uuid').nullable();
        table.string('avatar').nullable();
        table.string('address').nullable();
        table.boolean('active').nullable().defaultTo(true);
        table.timestamps();
    })
        .createTable('dialplans', (table) => {

            table.increments('id').primary();
            table.string('uuid').nullable();
            table.string('extensions').nullable().unique();
            table.integer('user_id').references('users.id');
        })
        .createTable('emergencies', (table) => {

            table.increments('id').primary();
            table.string('uuid').nullable();
            table.string('auditPath').nullable();
            table.string('toBeContacted').nullable();
            table.string('contacted').nullable();
            table.boolean('active').nullable().defaultTo(true);
            table.boolean('cancelled').nullable().defaultTo(false);
            table.integer('user_id').references('users.id');
            table.timestamps();
        });

};

exports.down = function (knex, Promise) {

    return knex.schema.dropTable('users')
        .dropTable('dialplans');
};
