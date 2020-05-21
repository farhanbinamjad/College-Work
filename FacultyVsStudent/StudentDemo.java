public class StudentDemo
{
   public static void main(String[] args)
   {
      Student student1 = new Student("hamad", "123222", 15, 92.2);
      student1.addCredits(23);
      Student student2 = new Student("Farhan", "685530", 17, 52.68);
      student2.changeName("Noman");
      System.out.println(student1.getLoginName());
      System.out.println(student2.getLoginName());
      System.out.println(student1.getName());
      System.out.println(student2.getName());
   	
   }
}