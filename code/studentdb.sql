--use master
use master;
go
--drop student database

drop database studentdb;
go
--create new database
create database studentdb
on primary (
	name='student_data_file',
	filename='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\student_data_file.mdf',
	size=10mb,
	maxsize=100mb,
	filegrowth=10%
)
log on (
	name='student_log_file',
	filename='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\student_log_file.mdf',
	size=5mb,
	maxsize=50mb,
	filegrowth=1mb
);
go

--use 
use studentdb;
go

--students table
create table Students(
	  StudentID int Primary Key identity(1 ,1),
      FirstName varchar(255),
      LastName varchar(255),
      DateOfBirth date,
      Gender varchar(50),
      Address varchar(255),
      PhoneNumber varchar(55),
      Email varchar(255),
      AdmissionDate date

);
go

--courses table
create table Courses(
	  CourseID int Primary Key identity(1,1),
      CourseName varchar(255),
      Description varchar(255),
      Credits int
);
go

--enrollments table
create table Enrollments(
	  EnrollmentID int Primary Key identity(1,1),
      StudentID int references Students(StudentID),
      CourseID int  references Courses(CourseID),
      EnrollmentDate date,
      Grade char(2)
);
go

--exam table
create table Exams(
	ExamID int Primary Key identity(1,1),
	CourseID int references Courses(CourseID),
	ExamDate date,
	TotalMarks int
);
go
--result table
create table Results(
	  ResultID int Primary Key identity(1,1),
      StudentID int references Students(StudentID),
      ExamID int references Exams(ExamID),
      MarksObtained float
);
go

--store procedure of add student
create proc AddStudent(
	@FirstName varchar(255),
    @LastName varchar(255),
    @DateOfBirth date,
    @Gender varchar(50),
    @Address varchar(255),
    @PhoneNumber varchar(55),
    @Email varchar(255),
    @AdmissionDate date
)
as
begin
	if @DateOfBirth > getdate()
		begin
			raiserror('Invalid date of birth',16,1);
		end
	else if @PhoneNumber  like('%[^0-9]%') or len(@PhoneNumber)<>11
		begin
			raiserror('Invalid Number',16,1);
		end
	else if right(@Email,10) <> '@gmail.com'
		begin
			raiserror('Invalid Email',16,1);
		end
	 else if @AdmissionDate > getdate()
		begin
			raiserror('Invalid admission date ',16,1);
		end
	else
		begin
			insert into Students(FirstName,LastName,DateOfBirth,Gender,Address,PhoneNumber,Email,AdmissionDate)
			values(@FirstName,@LastName,@DateOfBirth,@Gender,@Address,@PhoneNumber,@Email,@AdmissionDate)
			print('Student add successfuly');
		end
end;
go

EXEC AddStudent
    @FirstName = 'samaul',
    @LastName = 'islam',
    @DateOfBirth = '2005-05-15',
    @Gender = 'M',
    @Address = '123 Elm Street',
    @PhoneNumber = '01234556904',
    @Email = 'samaul@gmail.com',
    @AdmissionDate = '2022-08-01';


select * from Students;
go

--insert Course table
INSERT INTO Courses (CourseName, Description, Credits)
VALUES 
('C Programming', 'Introduction to the C programming language.', 3),
('C++ Programming', 'Advanced study of object-oriented programming using C++.', 4),
('C# Programming', 'Overview of the C# language features.', 3);
go

--Enrollments store procedure
create proc EnrollStudent(
	@StudentID int,
    @CourseID int,
    @EnrollmentDate date,
    @Grade char(2)
)
as
begin
	if not exists(select 1 from Students where @StudentID=StudentID)
	begin
		raiserror('not avaible student',16,1)
	end
	else if not exists(select 1 from Courses where @CourseID=CourseID)
	begin
		raiserror('not avaible Course',16,1)
	end
	else if @EnrollmentDate > getdate()
	begin
		raiserror('Invalie date',16,1)
	end
	else
	begin
		insert into Enrollments(StudentID,CourseID,EnrollmentDate,Grade)
		values(@StudentID,@CourseID,@EnrollmentDate,@Grade);
	end
end;
go
--EnrollStudent insert values

exec EnrollStudent
	@StudentID = 1,
	@CourseID=1,
	@EnrollmentDate='2011-01-01',
	@Grade = 'A';
	go


select * from Enrollments;
go

--add exam proc
create proc AddExam(
	@CourseID int,
	@ExamDate date,
	@TotalMarks int
)
as
begin
	if not exists(select 1 from Courses where @CourseID=CourseID)
	begin
		raiserror('not avaible Course',16,1)
	end
	else if @ExamDate > getdate()
	begin
		raiserror('Invalie date',16,1)
	end
	else if @TotalMarks < 0
	begin
		raiserror('mark can not negetiv value',16,1)
	end
	else
	begin
		insert into Exams(CourseID, ExamDate,TotalMarks)
		values(@CourseID, @ExamDate,@TotalMarks);
	end
end;
go

exec AddExam @CourseId=1,
	@ExamDate='2022-01-01',
	@TotalMarks = 99;
go

--select 
select * from Exams;
go

--proc result table
create proc AddResult(
	@StudentID int,
    @ExamID int,
    @MarksObtained float
)
as
begin
	if not exists(select 1 from Students where @StudentID= StudentID)
		begin
			raiserror ('Student not avbile',16,1);
		end
	else if not exists(select 1 from Exams where @ExamID= ExamID)
		begin
			raiserror ('Exam not avbile',16,1);
		end
	else if @MarksObtained <0
		begin
			raiserror('mark can not negetive value',16,1);
		end
	else
		begin
			insert into Results(ExamID,MarksObtained)
			values(@ExamID,@MarksObtained)
		end
end;
go

exec AddResult @StudentId=1,
@ExamId=1,@marksObtained=2.2;
go

--update result on trigger
--create trigger