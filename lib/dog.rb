class Dog
    attr_accessor :id, :name, :breed

    def initialize(id:nil, name:, breed:)
        @id, @name, @breed = id, name, breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def save
        if self.id
            self.update
        else
            sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end

    def self.create(hash)
        self.new(hash).save
    end

    def self.new_from_db(row)
        id, name, breed = row
        self.new(id:id, name:name, breed:breed)
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        DB[:conn].execute(sql, id).map{|dog| new_from_db(dog)}[0]
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            data = dog[0]
            dog = self.new_from_db(data)
        else
            dog = self.create(name:name, breed:breed)
        end
        dog
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        DB[:conn].execute(sql, name).map{|dog| new_from_db(dog)}[0]
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end