require 'sqlite3'
require 'singleton'
require 'byebug'

class QuestionsDatabase < SQLite3::Database
  include Singleton
  
  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class QuestionFollow
  attr_reader :id, :user_id, :question_id
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollow.new(datum) }
  end
  
  def self.find_by_id(id)
    question_follower = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL
  end
  
  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
  
  def create
    raise "#{self} already in DB" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id)
      INSERT INTO
        question_follows (user_id, question_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end
  
  def update
    raise "#{self} not in DB" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id, @id)
      UPDATE
        question_follows
      VALUES
        user_id = ?, question_id = ?
      WHERE
        id = ?
    SQL
  end
end

class Reply
  attr_accessor :body
  attr_reader :id, :parent_id, :question_id, :user_id
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    data.map { |datum| Question.new(datum) }
  end
  
  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
  end
  
  def initialize(options)
    @id = options['id']
    @parent_id = options['parent_id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end
  
  def create
    raise "#{self} already in DB" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @parent_id, @question_id, @user_id)
      INSERT INTO
        replies (parent_id, question_id, user_id)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDatabase.last_insert_row_id
  end
  
  def update
    raise "#{self} not in DB" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @parent_id, @question_id, @user_id, @id)
      UPDATE
        replies
      VALUES
        parent_id = ?, question_id = ?, user_id = ?
      WHERE
        id = ?
    SQL
  end
end

















