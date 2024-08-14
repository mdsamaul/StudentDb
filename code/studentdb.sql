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
    @FirstName = 'Shihan',
    @LastName = 'Rhaman',
    @DateOfBirth = '2005-05-15',
    @Gender = 'M',
    @Address = '123 Elm Street',
    @PhoneNumber = '01234556904',
    @Email = 'shihan@gmail.com',
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

exec AddExam @CourseId=3,@ExamDate='2022-01-01',@TotalMarks = 66;
go
exec AddExam @CourseId=2,@ExamDate='2021-01-01',@TotalMarks = 88;
go
exec AddExam @CourseId=1,@ExamDate='2020-01-01',@TotalMarks = 77;
go
--select 
select * from Exams;
go
drop proc AddResult
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
			insert into Results(StudentID, ExamID,MarksObtained)
			values(@StudentID, @ExamID,@MarksObtained)
		end
end;
go

select * from Students;
go

exec AddResult @StudentId=1,
@ExamId=1, @MarksObtained=5.5;
go

select * from results;
go

truncate table results;
go

--update result on trigger
create trigger tri_UpdateResultOnGrade
on Results
after insert
as
begin
	declare @StudentId int, @ExamId int, @MarksObtained float;
	select @StudentId = inserted.StudentId, @ExamId=inserted.ExamId, @MarksObtained =inserted.marksObtained
	from inserted;

	declare @CourseId int;
	select @CourseId=CourseID from Exams where ExamID=@ExamId;

	declare @Grade char(2);
		set @Grade= case
			when @MarksObtained >=90 then 'A'
			when @MarksObtained >=80 then 'B'
			when @MarksObtained >=70 then 'C'
			when @MarksObtained >=60 then 'D'
			else 'F'
		end

	update Enrollments
	set Grade = @Grade
	where @StudentId=StudentID and @CourseId = CourseID;
end
go

drop trigger tri_UpdateResultOnGrade

CREATE TRIGGER tri_UpdateResultOnGrade
ON Results
AFTER INSERT
AS
BEGIN
    -- Process all inserted rows
    UPDATE Enrollments
    SET Grade = (
        CASE
            WHEN i.MarksObtained >= 90 THEN 'A'
            WHEN i.MarksObtained >= 80 THEN 'B'
            WHEN i.MarksObtained >= 70 THEN 'C'
            WHEN i.MarksObtained >= 60 THEN 'D'
            ELSE 'F'
        END
    )
    FROM Enrollments e
    INNER JOIN inserted i ON e.StudentID = i.StudentID
                           AND e.CourseID = (SELECT e2.CourseID FROM Exams e2 WHERE e2.ExamID = i.ExamID)
    WHERE i.ResultID IN (SELECT ResultID FROM inserted);
END;
GO


--insert result
insert into Exams
values(1,'2022-02-02',77);
go
