    API手册
* 常用数据类型
  * CVector     : 一个向量常用于表示速度，构造方法 local vel = CVector(x,y) 
  * CGeoPoint   : 一个坐标点，构造方法 local point = CGeoPoint(x,y)
  * CGeoLine    : 一条直线，确定一条直线的两个参数，1.直线的起点，2.直线的方向，构造方法 local line = CGeoLine(point,dir)
  * CGeoSegment : 一个线段，确定一条线段的两个参数1.线段的起点，2.线段的终点，构造方法 local segment = CGeoSegment(point1,point2)
  * dir         : 方向，弧度值,创建方法 local dir = 0(表示0度),local dir = math.pi (表示180度)

* 常用数据类型的方法
  * mod() :取两个坐标之间的模长，用法 local distance = (point1 - point2):mod()
  * dir() :取两个坐标的方向，用法 local direction = (point1 - point2):dir()
  * projection(point):获取一个线段或者直线相对某一坐标的投影点,类型是CGeoPoint,构造方法 local prjPoint = 



* 常用文件：
  * player
    * pos(role) : 获取坐标
    * posX(role)
    * posY(role)
    * dir(role)
    * vel(role)
    * velDir(role)
    * velMod(role)
    * rawVel(role)
    * rawVelMod(role)
    * rotVel(role)
    * valid(role)
    * pos(role)
    * posX(role)
  * ball
  * enemy
  * task
