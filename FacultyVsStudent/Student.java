/**
* Intermediate Computing 
*
* Homework #1 Student Class
*
* This is the Student class
*
* @Farhan Bin Amjad - CS 2530 - binamjf@uni.edu
*
* @version 1 - 2018-09-12
*
*/

public class Student
{
   //instance variables
   private String StudentName;
   private String idNumber;
   private int TotalCredits;
   private double GradePoints;
   
   
   //constructors
   public Student(String StudentName, String idNumber, 
                  int TotalCredits, double GradePoints)
   {
   
      this.StudentName = StudentName;
      this.idNumber = idNumber;
      this.TotalCredits = TotalCredits;
      this.GradePoints = GradePoints;
   
   } 
   
   //Functionality (methods)
   public String getName()
   {
   
      return StudentName;
   
   }
   
   public void changeName(String NewName)
   {
   
      StudentName = NewName;
   
   }
   
   public String getID()
   {
   
      return idNumber;
   }
   
   public void addCredits(int moreCredits)
   {
      int temp = TotalCredits;
      TotalCredits += moreCredits;
     
      if (TotalCredits < 0)
         {
          TotalCredits = temp;
         }
      else
         {
         TotalCredits = TotalCredits;
         }
   }
   
   public int getCredits()
   {
      return TotalCredits;
   
   }
   
   public void addGradePoints(double newGradePoints)
   {
      GradePoints += newGradePoints;
   
   }
   
   public double getGradePoints()
   {
      return GradePoints;
   
   } 
   
   public double getGPA()
   {
      double GPA = GradePoints/TotalCredits;
      return GPA;
   
   }
   
   public void getStatus()
   {
      if (TotalCredits < 30)
      
      {
      
         System.out.println(""+StudentName+" is a freshman");   
      
      }
      
      else if (TotalCredits >= 30 && TotalCredits < 60)
      {
      
         System.out.println(""+StudentName+" is a Sophomore");
      
      }
      
      else if (TotalCredits >= 60 && TotalCredits < 90)
      
      {
      
         System.out.println(""+StudentName+" is a Junior");
      
      }
      
      else
      {
      
         System.out.println(""+StudentName+" is a Senior");
      
      }
   
   }
   
   public String getLoginName()
   {
   
   String LoginName = StudentName.substring(0, 4);
   String LoginIDnumber = idNumber.substring(0,3); 
   String alltogether = LoginName+LoginIDnumber;
   
   return alltogether;
   
   }
   
   public void PrintInfo()
   {
   
   System.out.println(""+StudentName+" ("+idNumber+")");
   
   }
   
   public String toString()
   {
   
   String newString = ""+StudentName+" ("+idNumber+")";
   return newString;
   
   }   
 
}


   
   
   
   
   
 
