require_relative "../config/environment.rb"
require "pry"


class Student
  attr_accessor :id, :name, :tagline, :github, :twitter, :blog_url,
  :image_url, :biography

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        tagline TEXT,
        github TEXT,
        twitter TEXT,
        blog_url TEXT,
        image_url TEXT,
        biography TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
    SQL
    DB[:conn].execute(sql)
  end

  def insert
    sql = <<-SQL
      INSERT INTO students(name, tagline, github, twitter, blog_url, image_url, biography)
      VALUES(?, ?, ?, ?, ?, ?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.tagline, self.github, self.twitter, self.blog_url, self.image_url, self.biography)
    sql = <<-SQL
      SELECT id from students ORDER BY id DESC LIMIT 1
    SQL
    self.id = DB[:conn].execute(sql).flatten.first
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.id)
  end

  def save
    persisted? ? update : insert
  end

  def persisted?
    !!self.id
  end


  def self.new_from_db(row)
    Student.new.tap do |s|
      s.id = row[0]
      s.name = row[1]
      s.tagline = row[2]
      s.github = row[3]
      s.twitter = row[4]
      s.blog_url = row[5]
      s.image_url = row[6]
      s.biography = row[7]
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
    SQL

    data = DB[:conn].execute(sql, name).flatten
    if !(data.all?{|d| d.nil?})
      obj = Student.new.tap do |s|
        s.id = data[0]
        s.name = data[1]
        s.tagline = data[2]
        s.github = data[3]
        s.twitter = data[4]
        s.blog_url = data[5]
        s.image_url = data[6]
        s.biography = data[7]
      end
    end
  end
end
