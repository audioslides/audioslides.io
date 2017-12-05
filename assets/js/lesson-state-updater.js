import $ from "jquery";
import socket from './socket'

$(document).ready(() => {
  $('[data-lesson-id]').each((_index, elem) => {
    const lessonId = $(elem).data('lessonId');
    console.log("lessonId:", lessonId)

    const channel = socket.channel('lesson:' + lessonId, {})
    channel.join()
      .receive('ok', function(resp) { console.log('Joined successfully', resp) })
      .receive('error', function(resp) { console.log('Unable to join', resp) })

    channel.on('new-processing-state', payload => {
      console.log(jQuery(payload.lesson_html))
      $(elem).html(payload.lesson_html)
    })
  })
});
