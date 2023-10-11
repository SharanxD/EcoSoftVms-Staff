// ignore_for_file: non_constant_identifier_names

class Visitor{
  Visitor({required this.Name,required this.CompanyName,required this.phoneno,required this.EmailId,required this.Purpose,required this.id,required this.staff,required this.aadharnumber});
  final String Name;
  final String CompanyName;
  final String phoneno;
  final String EmailId;
  final String Purpose;
  final String id;
  final String staff;
  final String aadharnumber;
}
class Staff{
  Staff({required this.EmailId,required this.UserName,required this.phoneno,required this.ProfileLink});
  final String UserName;
  final String EmailId;
  final String phoneno;
  final String ProfileLink;
}
class LogBook{
  LogBook({required this.VisitorName, required this.Purpose,required this.Checkedin,required this.Checkedout,required this.id});
  final String VisitorName;
  final String Purpose;
  final String Checkedin;
  final String Checkedout;
  final String id;
}
class Requests{
  Requests({required this.ReqTime,required this.Name,required this.CompanyName,required this.phoneno,required this.EmailId,required this.Purpose,required this.id,required this.staff});
  final String Name;
  final String CompanyName;
  final String phoneno;
  final String EmailId;
  final String Purpose;
  final String id;
  final String staff;
  final String ReqTime;

}
class ExportDataform{
  ExportDataform({
    required this.Name,required this.CompanyName,required this.phoneno,required this.Purpose,required this.Emailid,required this.Indatetime,required this.Outdatetime
  });
  final String Name;
  final String CompanyName;
  final String phoneno;
  final String Emailid;
  final String Purpose;
  final String Indatetime;
  final String Outdatetime;
}