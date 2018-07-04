require 'sqlite3'
require 'singleton'
require_relative 'student_questions'
require_relative 'user'
require_relative 'reply'


class Question
  attr_accessor :title, :body, :user_id
  attr_reader :id
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end
  
  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    
    Question.new(question.first)
  end
  
  def self.find_by_author_id(user_id)
    question = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL
    # return nil unless question.length > 0
    # 
    # Question.new(question.first)
  end
  
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end
  
  def create
    raise "#{self} already in DB" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
      INSERT INTO
        questions(title, body, user_id)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end
  
  def update
    raise "#{self} not in DB" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id, @id)
      UPDATE
        questions
      VALUES
        title = ?, body = ?, user_id = ?
      WHERE
        id = ?
    SQL
  end
  
  def author
    "#{User.find_by_id(@user_id).fname} #{User.find_by_id(@user_id).lname}"
  end
  
  def replies
    Reply.find_by_question_id(@id)
  end
end