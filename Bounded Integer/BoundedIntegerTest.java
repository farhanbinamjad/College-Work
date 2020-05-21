/**
* Intermediate Computing 
*
* Homework #3 Bounded Integer Class ( J UNIT TEST)
*
* @Farhan Bin Amjad - CS 2530 - binamjf@uni.edu
*
* @version 1 - 2018-09-29
*
*/
import org.junit.Assert;
import static org.junit.Assert.*;
import org.junit.Before;
import org.junit.Test;


public class BoundedIntegerTest 
{
   private BoundedInteger bi1;
   private BoundedInteger bi2;

   /** Fixture initialization (common initialization
    *  for all tests). **/
   @Before public void setUp() 
   {
      bi1 = new BoundedInteger(20, 40);
      bi2 = new BoundedInteger(10, 20, 15);
   
   }

   @Test public void checksetvalue()
   {
      bi1.setvalue(21);
      assertEquals(21, bi1.getValue());
      bi2.setvalue(18);
      assertEquals(18, bi2.getValue());
      bi1.setvalue(32);
      assertEquals(32, bi1.getValue());
      bi2.setvalue(12);
      assertEquals(12, bi2.getValue());
      bi1.setvalue(20);
      assertEquals(20, bi1.getValue());
      bi2.setvalue(16);
      assertEquals(16, bi2.getValue());
   
   }
   
   
   @Test public void checkadd()
   {
      bi1.add(2);      
      assertEquals(22, bi1.getValue());
      bi1.setvalue(20);
      bi2.add(5);      
      assertEquals(20, bi2.getValue());
      bi2.setvalue(15);
      bi1.add(15);      
      assertEquals(35, bi1.getValue());
      bi1.setvalue(20);
      bi2.add(15);      
      assertEquals(19, bi2.getValue());
      bi2.setvalue(15);
      bi1.add(50);      
      assertEquals(28, bi1.getValue());
      bi1.setvalue(20);
      bi2.add(30);      
      assertEquals(12, bi2.getValue());
      bi2.setvalue(15); 
      
   }
  
  @Test public void checksubtract()
   {
      bi1.subtract(2);      
      assertEquals(39, bi1.getValue());
      bi1.setvalue(20);
      
      bi2.subtract(5);      
      assertEquals(10, bi2.getValue());
      bi2.setvalue(15);
      
      bi1.subtract(-15);      
      assertEquals(35, bi1.getValue());
      bi1.setvalue(20);
      
      bi2.subtract(15);      
      assertEquals(11, bi2.getValue());
      bi2.setvalue(15);
      
      bi1.subtract(50);      
      assertEquals(33, bi1.getValue());
      bi1.setvalue(20);
      
      bi2.subtract(-30);      
      assertEquals(12, bi2.getValue());
      bi2.setvalue(15); 
      
   }   



   @Test public void checkincrement()
   {
      
      bi1.increment();      
      assertEquals(21, bi1.getValue());
      bi1.setvalue(20);
      
      bi2.increment();      
      assertEquals(16, bi2.getValue());
      bi2.setvalue(15);
      
      bi1.setvalue(40);
      bi1.increment();      
      assertEquals(20, bi1.getValue());
      bi1.setvalue(20);

      bi2.setvalue(20);
      bi2.increment();
      assertEquals(10, bi2.getValue());

   
   }

   @Test public void checkdecrement()
   {
      
      bi1.decrement();      
      assertEquals(40, bi1.getValue());
      bi1.setvalue(20);
      
      bi2.decrement();      
      assertEquals(14, bi2.getValue());
      bi2.setvalue(15);
      
      bi1.setvalue(32);
      bi1.decrement();      
      assertEquals(31, bi1.getValue());
      bi1.setvalue(20);

      bi2.setvalue(10);
      bi2.decrement();
      assertEquals(20, bi2.getValue());

   }
   
   @Test public void checkequals()
   {
      assertEquals(true, bi1.equals(new BoundedInteger (20, 40)));
      assertEquals(false, bi1.equals(bi2));
      assertEquals(true, bi2.equals(new BoundedInteger (10, 20, 15)));
      assertEquals(false, bi2.equals(new BoundedInteger (10, 20)));
      assertEquals(false, bi1.equals(new BoundedInteger (20, 40, 21)));
      assertEquals(false, bi1.equals(new BoundedInteger (43, 56, 45)));
  
   
   } 


   @Test public void checkequivalentValue()
   {
      assertEquals(false, bi1.equivalentValue(new BoundedInteger (20, 40, 21)));
      assertEquals(false, bi1.equivalentValue(bi2));
      assertEquals(true, bi1.equivalentValue(new BoundedInteger (20, 40)));
      assertEquals(true, bi2.equivalentValue(new BoundedInteger (10, 20, 15)));
      assertEquals(true, bi1.equivalentValue(new BoundedInteger (20, 40, 20)));
      assertEquals(false, bi2.equivalentValue(bi1));
      assertEquals(false, bi1.equivalentValue(new BoundedInteger (10, 20, 15)));
  
   
   
   }

   @Test public void checkequivalentLowerLimit()
   {
      assertEquals(true, bi1.equivalentLowerLimit(new BoundedInteger (20, 40, 21)));
      assertEquals(false, bi1.equivalentLowerLimit(bi2));
      assertEquals(true, bi1.equivalentLowerLimit(new BoundedInteger (20, 50, 42)));
      assertEquals(true, bi2.equivalentLowerLimit(new BoundedInteger (10, 20, 15)));
      assertEquals(false, bi2.equivalentLowerLimit(new BoundedInteger (15, 20, 16)));
      assertEquals(false, bi2.equivalentLowerLimit(bi1));
      assertEquals(false, bi1.equivalentLowerLimit(new BoundedInteger (21, 40)));
      assertEquals(false, bi2.equivalentLowerLimit(new BoundedInteger (31,87, 32)));
   
   
   }

   @Test public void checkequivalentUpperLimit()
   {
      assertEquals(true, bi1.equivalentUpperLimit(new BoundedInteger (20, 40, 21)));
      assertEquals(false, bi1.equivalentUpperLimit(bi2));
      assertEquals(true, bi1.equivalentUpperLimit(new BoundedInteger (30, 40, 42)));
      assertEquals(true, bi2.equivalentUpperLimit(new BoundedInteger (10, 20, 15)));
      assertEquals(true, bi2.equivalentUpperLimit(new BoundedInteger (15, 20, 16)));
      assertEquals(false, bi2.equivalentUpperLimit(bi1));
      assertEquals(false, bi1.equivalentUpperLimit(new BoundedInteger (21, 41)));
      assertEquals(false, bi2.equivalentUpperLimit(new BoundedInteger (31,87, 32)));
      
   
   }

   @Test public void checkisLegal()
   {     
      assertEquals(true, bi1.isLegal(21));
      assertEquals(true, bi2.isLegal(14));
      assertEquals(false, bi1.isLegal(41));
      assertEquals(false, bi2.isLegal(28));
      assertEquals(false, bi1.isLegal(-1));
      assertEquals(false, bi2.isLegal(-5));
      assertEquals(true, bi1.isLegal(40));
      assertEquals(true, bi2.isLegal(20));
      assertEquals(false, bi1.isLegal(19));
      assertEquals(false, bi2.isLegal(9));
      assertEquals(true, bi1.isLegal(25));
      assertEquals(true, bi2.isLegal(13));
      assertEquals(false, bi1.isLegal(98));
      assertEquals(false, bi2.isLegal(312));
      assertEquals(false, bi1.isLegal(1));
      assertEquals(false, bi2.isLegal(0));
      assertEquals(false, bi1.isLegal(0));
      


   
   
   }


}
