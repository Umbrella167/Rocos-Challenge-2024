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
  * projection(point):获取一个(线段或者直线)相对某一坐标的投影点,返回的类型是CGeoPoint,构造方法 local prjPoint = segment:projection(point)
  * [eg](prjpoint.png)
  * IsPointOnLineOnSegment(point) : 判断某坐标点是否在线段上 用法: segment:IsPointOnLineOnSegment(point) 返回 true\false



* 常用文件：
  * player.lua \ enemy.lua 这两个文件大同小异 (role 一般填写机器人车号或者匹配的名字)     * 
    * num(role) : 获取我方机器人车号
    * name(role): 获取我方机器人名字
    * pos(role) : 获取我方机器人坐标  
    * posX(role) : 获取我方机器人X坐标
    * posY(role): 获取我方机器人Y坐标
    * dir(role): 获取我方机器人朝向
    * vel(role): 获取我方机器人速度
    * velDir(role): 获取我方机器人速度的方向
    * velMod(role): 获取我方机器人速度的大小
    * rawVel(role): 获取我方机器人真实速度
    * rawVelMod(role): 获取我方机器人真实速度大小
    * rotVel(role): 获取我方机器人旋转速度
    * valid(role): 获取我方机器人是否存在
    * infraredOn(role) :检测我方机器人红外是否触发
    * infraredCount(role) :检测我方机器人红外触发的帧数
    * kickBall(role) :判断我方机器人是否踢球
  * ball
    * pos() : 获取球的坐标
    * posX() : 获取球的X坐标
    * posY(): 获取球的Y坐标
    * rawPos() :获取球的真实坐标
    * vel() :获取球的速度
    * velX() :获取球x方向的速度
    * velY() :获取球y方向的速度
    * velDir() :获取球速度朝向
    * velMod() :获取球速度大小
    * valid() :获取球是否存在
    * toPlayerDir(role) :获取球到我方机器人的方向
    * toEnemyDir(role) :获取球到敌方机器人的方向
    * toPlayerDist(role) :获取球到我方机器人的距离
    * toEnemyDist(role) :获取球到敌方机器人的距离