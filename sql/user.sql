DROP TABLE IF EXISTS user;
CREATE TABLE IF NOT EXISTS user(
 	`uno` INT(4) NOT NULL AUTO_INCREMENT COMMENT '用户ID',   
 	`email` VARCHAR(100) NOT NULL DEFAULT 'GG@qq.com' COMMENT 'Email',
 	`telephone` VARCHAR(20) NOT NULL DEFAULT '010-12345678' COMMENT '密码',
 	`password` VARCHAR(100) NOT NULL DEFAULT '123456' COMMENT '密码',
 	PRIMARY KEY(`uno`)  
)ENGINE=INNODB DEFAULT CHARSET=utf8;

insert into user(email,telephone,password) values('283285356@qq.com','17520092105','asdfASDF>>>ok');
select uno, email , password from user where email =  '283285356@qq.com' and password = 'asdfASDF>>>ok';

DROP TABLE IF EXISTS MESSAGE_BOARD;
CREATE TABLE IF NOT EXISTS message_board (
	`mno` INT(4) NOT NULL AUTO_INCREMENT COMMENT 'message board ID',   
 	`email` VARCHAR(100) NOT NULL DEFAULT '匿名' COMMENT '姓名',
 	`message` VARCHAR(100) NOT NULL DEFAULT 'Hello World' COMMENT '留言',
 	PRIMARY KEY(`mno`)  
)ENGINE=INNODB DEFAULT CHARSET= utf8;
insert into message_board ( email , message ) values('283285356@qq.com' , 'Hello World');