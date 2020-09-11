require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
    def self.table_name 
        self.to_s.downcase.pluralize
    end 

    def self.column_names

        DB[:conn].results_as_hash = true
        
        sql = "pragma table_info('#{table_name}')"

        table_info = DB[:conn].execute(sql)
        column_names = []
        table_info.each do |column|
            column_names.push(column["name"])
        end 
        column_names.compact
        #binding.pry
    end 

    def initialize(options={})
        options.each do |property, value|
            self.send("#{property}=", value)
        end 
        #binding.pry
    end 

    def table_name_for_insert
        self.class.table_name
    end 

    def col_names_for_insert
        self.class.column_names.delete_if {|col| col == 'id'}.join(", ")
        #binding.pry
    end 

    def values_for_insert
        values = []
        self.class.column_names.each do |col_name|
            values << "'#{send(col_name)}'" unless send(col_name).nil?
        end 
        values.join(", ")
        #binding.pry
    end

    def save
        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end 

    def self.find_by_name(name)
        sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
        DB[:conn].execute(sql, name)
        #binding.pry
    end 

    # first solution does not work
    # def self.find_by(col_names_for_insert: values_for_insert)
        
    #     sql = "SELECT * FROM #{self.table_name} WHERE #{col_names_for_insert} = ?"
    #     DB[:conn].execute(sql, col_names_for_insert)
       
    # end 

    # second solution
    def self.find_by(attribute)
        # attribute needs to be hash with a key and a value
        # attribute key is the column
        # attribute value is the row
        # how to get each?
        # try:
        
        # the following does not work
        # attribute.each do |property, value|
        #     self.send("#{property}=", value)
        # end

        # try attribute.each_key / each_value
        #binding.pry
        # column_info = attribute.each_key
        # value_info = attribute.each_value

        sql = "SELECT * FROM #{self.table_name} WHERE #{attribute.keys[0].to_s} = ?"
        DB[:conn].execute(sql, attribute.values[0])
       
    end 

end