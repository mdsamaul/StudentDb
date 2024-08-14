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

--