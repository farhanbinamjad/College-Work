/**
* Intermediate Computing 
*
* Homework #1 Faculty class
*
* This is the Student class
*
* @Farhan Bin Amjad - CS 2530 - binamjf@uni.edu
*
* @version 1 - 2018-09-12
*
*/

public class Faculty
{
   //instance variables
   private String FacultyName;
   private String idNumber;
   private String OfficeNumber;
   private int NumberofCourses;
   private double Salary;
   
   
   //constructors
   public Faculty(String FacultyName, String idNumber, double Salary)
   {
   
      this.FacultyName = FacultyName;
      this.idNumber = idNumber;
      OfficeNumber = "Undefined";
      NumberofCourses = 2;
      this.Salary = Salary;
   
   } 
   
   //Functionality (methods)
   public String getName()
   {
   
      return FacultyName;
   
   }
   
   public void changeName(String NewName)
   {
   
      FacultyName = NewName;
   
   }
   
   public String getID()
   {
   
      return idNumber;
   }
   
   
   public String getOffice()
   {
      return OfficeNumber;
   
   }
   
   public void setOffice(String NewOffice)
   
  {
      String OfficeNumber = NewOffice;
  
  } 
   
   
   public void setCoursesTaught(int TeachingCourses)
   {
      NumberofCourses = TeachingCourses;
   
   }
   
   public int getCoursesTaught()
   {
      return NumberofCourses;
   
   } 
   
   
   
   public double getSalary()
   {
      return Salary;
   
   }
   
   public void setSalary(double newSalary)
   {
      Salary = newSalary;
   }
   
   public void giveRaise(double Raise)
   {
      double temp = Salary;
      Salary += Raise;
     
      if (Salary < 0)
         {
          Salary = temp;
         }
      else
         {
         Salary = Salary;
         }
   
   
   }
   
   public String getLoginName()
   {
   
   String LoginName = FacultyName.substring(0, 4);
   String LoginIDnumber = idNumber.substring(0,3); 
   String alltogether = LoginName+LoginIDnumber;
   
   return alltogether;
   
   }
   
   public void PrintInfo()
   {
   
   System.out.println(""+FacultyName+" ("+idNumber+") Office:"+OfficeNumber+"");
   
   }
   
   public String toString()
   {
   
   String newString = ""+FacultyName+" ("+idNumber+") Office:"+OfficeNumber+"";
   return newString;
   
   }   
 
}


   
   
   
   
   
 
