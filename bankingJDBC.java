// ANKIT JAIN
// 2020BTCSE004
// BANKING DATABASE

import java.sql.*;
import java.util.Scanner;

public class Main {
    public static void main(String[] args) throws SQLException,ClassNotFoundException {

        Class.forName("com.mysql.cj.jdbc.Driver");
        String url="jdbc:mysql://localhost:3306/";
        String username="root";
        String password="";
        Connection con = DriverManager.getConnection(url,username,password);
        Statement stmt=con.createStatement();

        stmt.execute("USE bankingSystem");

        String query1 = "SELECT cust_id,cust_fname,cust_street,cust_city,cust_phone,cust_email,Account.acc_no,acc_balance,Account.b_ifsc,Loan.l_id,l_amt,Loan.b_ifsc FROM Customer \n" +
                "LEFT JOIN Account ON Customer.acc_no = Account.acc_no\n" +
                "LEFT JOIN Loan ON Customer.l_id = Loan.l_id;";

        String query2  ="CALL transfer(?,?,?)";

        String query3 = "SELECT * FROM Transaction WHERE acc_no = ? && tr_Date >= CURRENT_TIMESTAMP - INTERVAL 30 DAY ORDER BY tr_date DESC , tr_id DESC;";

        String query4 = "CALL withdrawAmount(?,?);";

        String query5 = "CALL deposit(?,?);";

        CallableStatement st2 =con.prepareCall(query2);

        CallableStatement st4 =con.prepareCall(query4);

        CallableStatement st5 =con.prepareCall(query5);

        PreparedStatement ps = con.prepareStatement(query3);

        int x = 1;
        while(x == 1) {
            System.out.println("------------------ CHOOSE ------------------");
            System.out.println(" 1 to Get Customers complete profile information with current balance and Loan info if any.. ");
            System.out.println(" 2 to transfer fund from one account to another account.");
            System.out.println(" 3 to Retrieve the last month statements of any account number.");
            System.out.println(" 4 to Withdraw money from account.");
            System.out.println(" 5 to Deposit money to account.");
            System.out.println(" 6 to exit.");

            Scanner sc = new Scanner(System.in);
            int ch = sc.nextInt();
            ResultSet rs;
            ResultSetMetaData rsmd;
            switch (ch) {
                case 1 -> {
                    rs = stmt.executeQuery(query1);
                    rsmd = rs.getMetaData();
                    int columnsNumber = rsmd.getColumnCount();
                    for (int i = 1; i <= columnsNumber; i++) {
                        if (i > 1) System.out.print("\t");
                        System.out.print(rsmd.getColumnName(i));
                    }
                    System.out.println();
                    while (rs.next()) {
                        System.out.format("%4d%10s%21s%12s%18s%20s%10d%8d%15s%7d%8d%10s", rs.getInt(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getLong(5), rs.getString(6), rs.getInt(7), rs.getInt(8), rs.getString(9), rs.getInt(10), rs.getInt(11), rs.getString(12));
                        System.out.println();
                    }
                }
                case 2 -> {
                    System.out.println("Enter sender account no");
                    int acc1 = sc.nextInt();
                    System.out.println("Enter receiver account no");
                    int acc2 = sc.nextInt();
                    System.out.println("Enter amount to transfer");
                    int amt = sc.nextInt();
                    st2.setInt(1, acc1);
                    st2.setInt(2, acc2);
                    st2.setInt(3, amt);
                    rs = st2.executeQuery();
                    rs.next();
                    System.out.println(rs.getString(1));
                }
                case 3 -> {
                    System.out.println("Enter account no to get statements of last 1 month");
                    int ac = sc.nextInt();
                    ps.setInt(1, ac);
                    rs = ps.executeQuery();
                    rsmd = rs.getMetaData();
                    int columnsCount = rsmd.getColumnCount();
                    for (int i = 1; i <= columnsCount; i++) {
                        if (i > 1) System.out.print("\t\t");
                        if (i == 2) System.out.print("\t\t");
                        System.out.print(rsmd.getColumnName(i));
                    }
                    System.out.println();
                    while (rs.next()) {
                        System.out.format("%4d%26d%33s%10d%20d%38s", rs.getInt(1), rs.getInt(2), rs.getString(3), rs.getInt(4), rs.getInt(5), rs.getTimestamp(6));
                        System.out.println();
                    }
                }
                case 4 -> {
                    System.out.println("Enter account no");
                    int acc = sc.nextInt();
                    System.out.println("Enter amount to withdraw");
                    int amount = sc.nextInt();
                    st4.setInt(1, acc);
                    st4.setInt(2, amount);
                    rs = st4.executeQuery();
                    rs.next();
                    System.out.println(rs.getString(1));
                }
                case 5 -> {
                    System.out.println("Enter account no");
                    int account = sc.nextInt();
                    System.out.println("Enter amount to deposit");
                    int amnt = sc.nextInt();
                    st5.setInt(1, account);
                    st5.setInt(2, amnt);
                    rs = st5.executeQuery();
                    rs.next();
                    System.out.println(rs.getString(1));
                }
                case 6 -> x = 0;
            }
        }
        con.close();
    }

}
