/**
 * 京喜牧场
 * cron: 10 0,12,18 * * *
 */

import axios from 'axios'
import {Md5} from "ts-md5"
import * as path from 'path'
import {sendNotify} from './sendNotify'
import {requireConfig, getBeanShareCode, getFarmShareCode, wait, requestAlgo, h5st, exceptCookie, o2s} from './TS_USER_AGENTS'

const token = require('./utils/jd_jxmc.js').token

let cookie: string = '', res: any = '', shareCodes: string[] = [], homePageInfo: any, jxToken: any, UserName: string, index: number
let shareCodesHbSelf: string[] = [], shareCodesHbHw: string[] = [], shareCodesSelf: string[] = [], shareCodesHW: string[] = []

!(async () => {
  await requestAlgo()
  let cookiesArr: any = await requireConfig()
  if (process.argv[2]) {
    console.log('收到命令行cookie')
    cookiesArr = [decodeURIComponent(process.argv[2])]
  }
  let except: string[] = exceptCookie(path.basename(__filename))

  for (let i = 0; i < cookiesArr.length; i++) {
    cookie = cookiesArr[i]
    UserName = decodeURIComponent(cookie.match(/pt_pin=([^;]*)/)![1])
    index = i + 1
    console.log(`\n开始【京东账号${index}】${UserName}\n`)

    if (except.includes(encodeURIComponent(UserName))) {
      console.log('已设置跳过')
      continue
    }

    jxToken = await token(cookie)
    homePageInfo = await api('queryservice/GetHomePageInfo', 'activeid,activekey,channel,isgift,isqueryinviteicon,isquerypicksite,jxmc_jstoken,phoneid,sceneid,timestamp', {isgift: 1, isquerypicksite: 1, isqueryinviteicon: 1})
    await wait(5000)
    if (homePageInfo.data.maintaskId !== 'pause') {
      console.log('init...')
      for (let j = 0; j < 20; j++) {
        res = await api('operservice/DoMainTask', 'activeid,activekey,channel,jxmc_jstoken,phoneid,sceneid,step,timestamp', {step: homePageInfo.data.maintaskId})
        if (res.data.maintaskId === 'pause')
          break
        await wait(2000)
      }
    }

    homePageInfo = await api('queryservice/GetHomePageInfo', 'activeid,activekey,channel,isgift,isqueryinviteicon,isquerypicksite,jxmc_jstoken,phoneid,sceneid,timestamp', {isgift: 1, isquerypicksite: 1, isqueryinviteicon: 1})
    let lastgettime: number
    if (homePageInfo.data?.cow?.lastgettime) {
      lastgettime = homePageInfo.data.cow.lastgettime
    } else {
      continue
    }

    console.log('助力码:', homePageInfo.data.sharekey)
    shareCodesSelf.push(homePageInfo.data.sharekey)
    try {
      await makeShareCodes(homePageInfo.data.sharekey)
    } catch (e: any) {
      console.log(e)
    }

    // 红包
    res = await api('operservice/GetInviteStatus', 'activeid,activekey,channel,jxmc_jstoken,phoneid,sceneid,timestamp')
    console.log('红包助力:', res.data.sharekey)
    shareCodesHbSelf.push(res.data.sharekey)
    try {
      await makeShareCodesHb(res.data.sharekey)
    } catch (e: any) {
    }
    await wait(1000)
  }
  await wait(1000)
})()

interface Params {
  isgift?: number,
  isquerypicksite?: number,
  petid?: string,
  itemid?: string,
  type?: string,
  taskId?: number
  configExtra?: string,
  sharekey?: string,
  currdate?: string,
  token?: string,
  isqueryinviteicon?: number,
  showAreaTaskFlag?: number,
  jxpp_wxapp_type?: number,
  dateType?: string,
  step?: string,
  cardtype?: number,
}

async function getTask() {
  console.log('刷新任务列表')
  res = await api('GetUserTaskStatusList', 'bizCode,dateType,jxpp_wxapp_type,showAreaTaskFlag,source', {dateType: '', showAreaTaskFlag: 0, jxpp_wxapp_type: 7})
  for (let t of res.data.userTaskStatusList) {
    if (t.completedTimes == t.targetTimes && t.awardStatus === 2) {
      res = await api('Award', 'bizCode,source,taskId', {taskId: t.taskId})
      if (res.ret === 0) {
        let awardCoin = res.data.prizeInfo.match(/:(.*)}/)![1] * 1
        console.log('领奖成功:', awardCoin)
        await wait(4000)
        return 1
      } else {
        console.log('领奖失败:', res)
        return 0
      }
    }

    if (t.dateType === 2 && t.completedTimes < t.targetTimes && t.awardStatus === 2 && t.taskType === 2) {
      res = await api('DoTask', 'bizCode,configExtra,source,taskId', {taskId: t.taskId, configExtra: ''})
      if (res.ret === 0) {
        console.log('任务完成')
        await wait(5000)
        return 1
      } else {
        console.log('任务失败:', res)
        return 0
      }
    }
  }
  return 0
}

async function api(fn: string, stk: string, params: Params = {}, temporary: boolean = false) {
  let url: string
  if (['GetUserTaskStatusList', 'DoTask', 'Award'].indexOf(fn) > -1) {
    if (temporary)
      url = h5st(`https://m.jingxi.com/newtasksys/newtasksys_front/${fn}?_=${Date.now()}&source=jxmc_zanaixin&bizCode=jxmc_zanaixin&_stk=${encodeURIComponent(stk)}&_ste=1&sceneval=2&g_login_type=1&callback=jsonpCBK${String.fromCharCode(Math.floor(Math.random() * 26) + "A".charCodeAt(0))}&g_ty=ls`, stk, params, 10028)
    else
      url = h5st(`https://m.jingxi.com/newtasksys/newtasksys_front/${fn}?_=${Date.now()}&source=jxmc&bizCode=jxmc&_stk=${encodeURIComponent(stk)}&_ste=1&sceneval=2&g_login_type=1&callback=jsonpCBK${String.fromCharCode(Math.floor(Math.random() * 26) + "A".charCodeAt(0))}&g_ty=ls`, stk, params, 10028)
  } else {
    url = h5st(`https://m.jingxi.com/jxmc/${fn}?channel=7&sceneid=1001&activeid=jxmc_active_0001&activekey=null&jxmc_jstoken=${jxToken['farm_jstoken']}&timestamp=${jxToken['timestamp']}&phoneid=${jxToken['phoneid']}&_stk=${encodeURIComponent(stk)}&_ste=1&_=${Date.now()}&sceneval=2`, stk, params, 10028)
  }
  try {
    let {data}: any = await axios.get(url, {
      headers: {
        'Host': 'm.jingxi.com',
        'User-Agent': `jdpingou;`,
        'Referer': 'https://st.jingxi.com/pingou/jxmc/index.html',
        'Cookie': cookie
      }
    })
    if (typeof data === 'string')
      return JSON.parse(data.replace(/\n/g, '').match(/jsonpCBK.?\(([^)]*)/)![1])
    return data
  } catch (e: any) {
    return {}
  }
}

async function makeShareCodes(code: string) {
  try {
    let bean: string = await getBeanShareCode(cookie)
    let farm: string = await getFarmShareCode(cookie)
    let pin: string = Md5.hashStr(cookie.match(/pt_pin=([^;]*)/)![1])
    let {data}: any = await axios.get(`https://api.jdsharecode.xyz/api/autoInsert/jxmc?sharecode=${code}&bean=${bean}&farm=${farm}&pin=${pin}`)
    console.log(data.message)
  } catch (e) {
    console.log('自动提交失败')
    console.log(e)
  }
}

async function makeShareCodesHb(code: string) {
  try {
    let bean: string = await getBeanShareCode(cookie)
    let farm: string = await getFarmShareCode(cookie)
    let pin: string = Md5.hashStr(cookie.match(/pt_pin=([^;]*)/)![1])
    let {data}: any = await axios.get(`https://api.jdsharecode.xyz/api/autoInsert/jxmchb?sharecode=${code}&bean=${bean}&farm=${farm}&pin=${pin}`, {timeout: 10000})
    console.log(data.message)
  } catch (e) {
    console.log('自动提交失败')
    console.log(e)
  }
}

async function getCodes() {
  try {
    let {data}: any = await axios.get('https://api.jdsharecode.xyz/api/HW_CODES')
    shareCodesHW = data.jxmc || []
    shareCodesHbHw = data.jxmchb || []
  } catch (e) {
  }
}