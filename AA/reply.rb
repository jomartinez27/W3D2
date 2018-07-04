require 'sqlite3'
require 'singleton'
require_relative 'student_questions'
require_relative 'question'

class Reply
  attr_accessor :body
  attr_reader :id, :parent_id, :question_id, :user_id
  
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end
  
  def self.find_by_user_id(user_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
  end
  
  def self.find_by_question_id(question_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
  end
  
  def initialize(options)
    @id = options['id']
    @parent_id = options['parent_id']
    @question_id = options['question_id']
    @body = options['body']
    @user_id = options['user_id']
  end
  
  def create
    raise "#{self} already in DB" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @parent_id, @question_id, @body, @user_id)
      INSERT INTO
        replies (parent_id, question_id, body, user_id)
      VALUES
        (?, ?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
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
  
  def author
    "#{User.find_by_id(@user_id).fname} #{User.find_by_id(@user_id).lname}"
  end
  
  def question
    Question.find_by_id(@question_id)
  end
end