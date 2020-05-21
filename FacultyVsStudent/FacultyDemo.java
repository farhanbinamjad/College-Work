public class FacultyDemo
{
   public static void main(String[] args)
   {
      Faculty faculty1 = new Faculty("Atif", "123222", 1521323);
      faculty1.setOffice("ITTC 319");
      Faculty faculty2 = new Faculty("Farhan", "31231", 172342);
      faculty2.changeName("Ahsan");
      System.out.println(faculty1.getLoginName());
      System.out.println(faculty2.getLoginName());
      System.out.println(faculty1.toString());
      System.out.println(faculty2.getName());
   	
   }
}