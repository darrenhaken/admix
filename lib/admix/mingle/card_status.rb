class CardStatus

  NEXT = 'Next'
  QA = 'QA'
  QA_DONE = 'QA done'
  DEV = 'Dev'
  DEV_DONE = 'Dev done'
  AD = 'A & D'
  AD_DONE = 'A & D done'
  LIVE = 'Done (Deployed to Live)'
  
  def self.LIVE
    LIVE
  end

  def self.NEXT
    NEXT
  end

  def self.QA
    QA
  end

  def self.QA_DONE
    QA_DONE
  end

  def self.DEV
    DEV
  end

  def self.DEV_DONE
    DEV_DONE
  end

  def self.AD
    AD
  end

  def self.AD_DONE
    AD_DONE
  end
end