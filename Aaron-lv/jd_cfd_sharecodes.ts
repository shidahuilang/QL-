/**
 * 京喜财富岛
 * 包含雇佣导游，建议每小时1次
 * 使用jd_env_copy.js同步js环境变量到ts
 * 使用jd_ts_test.ts测试环境变量
 *
 * cron: 0 * * * *
 */

import axios from 'axios'
import {Md5} from 'ts-md5'
import {getDate} from 'date-fns'
import {requireConfig, wait, requestAlgo, h5st, getJxToken, getBeanShareCode, getFarmShareCode, o2s, randomString} from './TS_USER_AGENTS.ts'

const axi = axios.create({timeout: 10000})

let cookie: string = '', res: any = '', UserName: string, index: number
let shareCodes: string[] = [], shareCodesSelf: string[] = [], shareCodesHW: string[] = [], isCollector: Boolean = false, token: any = {}

interface Params {
  strBuildIndex?: string,
  ddwCostCoin?: number,
  taskId?: number,
  dwType?: string,
  configExtra?: string,
  strStoryId?: string,
  triggerType?: number,
  ddwTriggerDay?: number,
  ddwConsumeCoin?: number,
  dwIsFree?: number,
  ddwTaskId?: string,
  strShareId?: string,
  strMarkList?: string,
  dwSceneId?: string,
  strTypeCnt?: string,
  dwUserId?: number,
  ddwCoin?: number,
  ddwMoney?: number,
  dwPrizeLv?: number,
  dwPrizeType?: number,
  strPrizePool?: string,
  dwFirst?: any,
  dwIdentityType?: number,
  strBussKey?: string,
  strMyShareId?: string,
  ddwCount?: number,
  __t?: number,
  strBT?: string,
  dwCurStageEndCnt?: number,
  dwRewardType?: number,
  dwRubbishId?: number,
  strPgtimestamp?: number,
  strPhoneID?: string,
  strPgUUNum?: string,
  showAreaTaskFlag?: number,
  strVersion?: string,
  strIndex?: string
  strToken?: string
  dwGetType?: number,
  ddwSeaonStart?: number,
  size?: number,
  type?: number,
  strLT?: string,
  dwQueryType?: number,
  dwPageIndex?: number,
  dwPageSize?: number,
  dwProperty?: number,
  bizCode?: string,
  dwCardType?: number,
  strCardTypeIndex?: string,
  dwIsReJoin?: number,
}

!(async () => {
  await requestAlgo()
  let cookiesArr: any = await requireConfig()
  for (let i = 0; i < cookiesArr.length; i++) {
    cookie = cookiesArr[i]
    UserName = decodeURIComponent(cookie.match(/pt_pin=([^;]*)/)![1])
    index = i + 1
    console.log(`\n开始【京东账号${index}】${UserName}\n`)

    token = getJxToken(cookie)
    try {
      await makeShareCodes()
    } catch (e) {
      console.log("上车?错误！")
	  continue
    }
  }

})()

async function api(fn: string, stk: string, params: Params = {}, taskPosition = '') {
  let url: string
  if (['GetUserTaskStatusList', 'Award', 'DoTask'].includes(fn)) {
    let bizCode: string
    if (!params.bizCode) {
      bizCode = taskPosition === 'right' ? 'jxbfddch' : 'jxbfd'
    } else {
      bizCode = params.bizCode
    }
    url = `https://m.jingxi.com/newtasksys/newtasksys_front/${fn}?strZone=jxbfd&bizCode=${bizCode}&source=jxbfd&dwEnv=7&_cfd_t=${Date.now()}&ptag=&_stk=${encodeURIComponent(stk)}&_ste=1&_=${Date.now()}&sceneval=2&g_login_type=1&callback=jsonpCBK${String.fromCharCode(Math.floor(Math.random() * 26) + "A".charCodeAt(0))}&g_ty=ls`
  } else {
    url = `https://m.jingxi.com/jxbfd/${fn}?strZone=jxbfd&bizCode=jxbfd&source=jxbfd&dwEnv=7&_cfd_t=${Date.now()}&ptag=&_stk=${encodeURIComponent(stk)}&_ste=1&_=${Date.now()}&sceneval=2&g_login_type=1&callback=jsonpCBK${String.fromCharCode(Math.floor(Math.random() * 26) + "A".charCodeAt(0))}&g_ty=ls`
  }
  url = h5st(url, stk, params, 10032)
  let {data} = await axios.get(url, {
    headers: {
      'Host': 'm.jingxi.com',
      'Accept': '*/*',
      'Connection': 'keep-alive',
      'Accept-Language': 'zh-CN,zh-Hans;q=0.9',
      'User-Agent': `jdpingou;iPhone;4.13.0;14.4.2;${randomString(40)};network/wifi;model/iPhone10,2;appBuild/100609;supportApplePay/1;hasUPPay/0;pushNoticeIsOpen/1;hasOCPay/0;supportBestPay/0;session/${Math.random() * 98 + 1};pap/JA2019_3111789;brand/apple;supportJDSHWK/1;Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148`,
      'Referer': 'https://st.jingxi.com/',
      'Cookie': cookie
    }
  })
  if (typeof data === 'string') {
    try {
      return JSON.parse(data.replace(/\n/g, '').match(/jsonpCBK.?\(([^)]*)/)![1])
    } catch (e) {
      console.log(data)
      return ''
    }
  } else {
    return data
  }
}

async function task() {
  console.log('刷新任务列表')
  res = await api('GetUserTaskStatusList', '_cfd_t,bizCode,dwEnv,ptag,showAreaTaskFlag,source,strZone,taskId', {taskId: 0, showAreaTaskFlag: 1})
  await wait(2000)
  for (let t of res.data.userTaskStatusList) {
    if (t.awardStatus === 2 && t.completedTimes === t.targetTimes) {
      console.log('可领奖:', t.taskName)
      res = await api('Award', '_cfd_t,bizCode,dwEnv,ptag,source,strZone,taskId', {taskId: t.taskId, bizCode: t.bizCode})
      await wait(2000)
      if (res.ret === 0) {
        try {
          res = JSON.parse(res.data.prizeInfo)
          console.log(`领奖成功:`, res.ddwCoin, res.ddwMoney)
        } catch (e) {
          console.log('领奖成功:', res.data)
        }
        await wait(1000)
        return 1
      } else {
        console.log('领奖失败:', res)
        return 0
      }
    }
    if (t.dateType === 2 && t.awardStatus === 2 && t.completedTimes < t.targetTimes && t.taskCaller === 1) {
      console.log('做任务:', t.taskId, t.taskName, t.completedTimes, t.targetTimes)
      res = await api('DoTask', '_cfd_t,bizCode,configExtra,dwEnv,ptag,source,strZone,taskId', {taskId: t.taskId, configExtra: '', bizCode: t.bizCode})
      await wait(5000)
      if (res.ret === 0) {
        console.log('任务完成')
        return 1
      } else {
        console.log('任务失败')
        return 0
      }
    }
  }
  return 0
}

async function makeShareCodes() {
  try {
    res = await api('user/QueryUserInfo', '_cfd_t,bizCode,ddwTaskId,dwEnv,ptag,source,strPgUUNum,strPgtimestamp,strPhoneID,strShareId,strVersion,strZone', {
      ddwTaskId: '',
      strShareId: '',
      strMarkList: 'undefined',
      strPgUUNum: token.strPgUUNum,
      strPgtimestamp: token.strPgtimestamp,
      strPhoneID: token.strPhoneID,
      strVersion: '1.0.1'
    })
    console.log('助力码:', res.strMyShareId)
    shareCodesSelf.push(res.strMyShareId)
    let bean: string = await getBeanShareCode(cookie)
    let farm: string = await getFarmShareCode(cookie)
    let pin: string = Md5.hashStr(cookie.match(/pt_pin=([^;]*)/)![1])
    let {data}: any = await axios.get(`https://api.jdsharecode.xyz/api/autoInsert/jxcfd?sharecode=${res.strMyShareId}&bean=${bean}&farm=${farm}&pin=${pin}`)
    console.log(data.message)
  } catch (e) {
    console.log('自动提交失败')
    //console.log(e)
  }
}

async function getCodesHW() {
  try {
    let {data}: any = await axi.get(`https://api.jdsharecode.xyz/api/HW_CODES`, {timeout: 10000})
    shareCodesHW = data['jxcfd'] || []
  } catch (e) {
  }
}